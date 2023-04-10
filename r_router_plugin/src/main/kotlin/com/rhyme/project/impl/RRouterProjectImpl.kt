package com.rhyme.project.impl

import com.intellij.codeInsight.actions.ReformatCodeProcessor
import com.intellij.openapi.project.Project
import com.intellij.openapi.vfs.VirtualFile
import com.intellij.psi.PsiDirectory
import com.intellij.psi.PsiFile
import com.intellij.psi.PsiManager
import com.intellij.psi.util.PsiTreeUtil
import com.jetbrains.lang.dart.psi.*
import com.jetbrains.lang.dart.psi.impl.DartVarDeclarationListImpl
import com.rhyme.entity.GenerateClassParamEntity
import com.rhyme.entity.GenerateClassParamsType.*
import com.rhyme.entity.GenerateEntity
import com.rhyme.entity.GenerateType
import com.rhyme.project.RRouterProject
import com.rhyme.utils.CodeUtils
import com.rhyme.utils.FileUtils
import com.rhyme.utils.SourceUtils
import io.flutter.run.daemon.FlutterApp

class RRouterProjectImpl(val mProject: Project) : RRouterProject {
    private var pubSpecConfig: FileUtils.PubSpecConfig? = null
    val pageList: MutableList<PageEntity> = mutableListOf()
    val routerFileName = "r_router_page_gen.dart"
    val routerMetaName = "RRouterPageMeta"
    val routerErrorPageMeta = "ErrorPageMeta"

    init {
        pubSpecConfig = FileUtils.getPubSpecConfig(mProject)
    }


    override fun generateRouters() {
        pageList.clear()
        //自动创建路由
        val willCreateRouterDirectory = FileUtils.getRouterDirectory(mProject)

        //创建路由文件
        val routerFile = (willCreateRouterDirectory.findChild(routerFileName)
            ?: willCreateRouterDirectory.createChildData(
                this,
                routerFileName
            ))

        val pageDirectory = FileUtils.getLibDirectory(mProject)

        generatePageEntity(mProject, pageDirectory!!)


        routerFile.setBinaryContent(
            CodeUtils.createRouters(
                pageList.map { it.importString },
                pageList.map { it.paramsName ?: "" },
                pageList.map { it.registerString },
                pageList.map { it.toRoute ?: "" },
            ).toByteArray()
        )
        val processor = ReformatCodeProcessor(PsiManager.getInstance(mProject).findFile(routerFile)!!, false)
        processor.run()

//        JumpToSourceAction
//        CodeStyleManager.getInstance(mProject).reformat(PsiManager.getInstance(mProject).findFile(routerFile)!!)
    }

    //构建所有页面对应的路由
    private fun generatePageEntity(mProject: Project, file: VirtualFile) {
        val childrenList = PsiManager.getInstance(mProject).findDirectory(file)!!.children
        for (children in childrenList) {
            if (children is PsiDirectory) {
                generatePageEntity(mProject, children.virtualFile)
            } else if (children is PsiFile && children is DartFile) {
                val generateEntities = mutableListOf<GenerateEntity>()
                val dartFile: DartFile = children
                val dartClasses = PsiTreeUtil.findChildrenOfAnyType(dartFile, false, DartClassDefinition::class.java)
                for (dartClass in dartClasses) {
                    //页面名字
                    //是否为页面，是否添加RouterMeta
                    val classParamList = mutableListOf<GenerateClassParamEntity>()

                    val className = dartClass.componentName.text
                    val metaData = SourceUtils.getMetaData(dartClass)
                    val fields: List<DartComponent> = dartClass.fields
                    for (dc in fields) {
                        val dc_list: DartVarDeclarationListImpl = dc.context as DartVarDeclarationListImpl
                        //获取类型
                        val type = dc_list.varAccessDeclaration.type?.text ?: continue
                        val name = dc_list.varAccessDeclaration.componentName.name
                        dc_list.varAccessDeclaration.type?.reference

                        val typeVirtualFile = dc_list.varAccessDeclaration.type?.resolveReference()?.containingFile?.virtualFile
                        val typeImportString = if (typeVirtualFile != null && !typeVirtualFile.path.contains("bin/cache")) {
                            FileUtils.getLibFromRootPath(typeVirtualFile).let {
                                if (it.isEmpty()) {
                                    null
                                } else {
                                    it.joinToString(separator = "/")
                                }
                            }
                        } else {
                            null
                        }
                        if (name != null && name != "key" && type != "key") {
                            val metaDataList = SourceUtils.getMetaDate(dc_list.varAccessDeclaration)
                            if (metaDataList.isEmpty()) {
                                classParamList.add(
                                    GenerateClassParamEntity(
                                        name,
                                        name,
                                        type,
                                        BODY,
                                        null,
                                        typeImportString
                                    )
                                )
                            } else {
                                when (metaDataList.first().metaName) {
                                    "RRouterQueryMeta" -> {
                                        classParamList.add(
                                            GenerateClassParamEntity(
                                                name,
                                                metaDataList.first().metaParams["name"] ?: name,
                                                type,
                                                QUERY,
                                                metaDataList.first().metaParams["def"],
                                                typeImportString
                                            )
                                        )
                                    }

                                    "RRouterPathMeta" -> {
                                        classParamList.add(
                                            GenerateClassParamEntity(
                                                name,
                                                metaDataList.first().metaParams["name"] ?: name,
                                                type,
                                                PATH,
                                                metaDataList.first().metaParams["def"],
                                                typeImportString
                                            )
                                        )
                                    }

                                    "RRouterBodyMeta" -> {
                                        classParamList.add(
                                            GenerateClassParamEntity(
                                                name,
                                                metaDataList.first().metaParams["name"] ?: name,
                                                type,
                                                BODY,
                                                metaDataList.first().metaParams["def"],
                                                typeImportString
                                            )
                                        )
                                    }
                                }
                            }
                        }
                    }
                    if (metaData.metaName == routerMetaName || metaData.metaName == routerErrorPageMeta) {
                        val generateType: GenerateType =
                            if (metaData.metaName == routerMetaName) {
                                GenerateType.PAGE
                            } else {
                                GenerateType.ERROR
                            }
                        generateEntities.add(
                            GenerateEntity(
                                children.name.substring(0, children.name.length - 5),
                                FileUtils.getLibFromRootPath(children.virtualFile)
                                    .joinToString(separator = "/"),
                                className,
                                metaData.metaParams,
                                generateType,
                                classParamList,
                            )
                        )
                    }
                }
                for (item in generateEntities) {
                    if (item.generateType == GenerateType.PAGE) {
                        //导包内容
                        val importStringList = mutableSetOf<String>()
                        importStringList.add("import 'package:${pubSpecConfig!!.name}/${item.importName}' as ${item.fileName};")
                        for (typeNeedInput in item.classParamsList) {
                            if(typeNeedInput.typeImport==null) continue
                            importStringList.add("import 'package:${pubSpecConfig!!.name}/${typeNeedInput.typeImport}';")
                        }
                        // 路径
                        val path = if (item.constructorParam["path"] != null) {
                            "${item.constructorParam["path"]}"
                        } else {
                            item.importName
                        }

                        var paramsName = item.constructorParam["paramsName"].toString().let {
                            it.replace("\'", "").replace("\"", "")
                        }
                        if(paramsName == "null"){

                            if(item.className.length > 1){
                                paramsName = "${item.className.substring(0,1).lowercase()}${item.className.substring(1,item.className.length)}"
                            }else{
                                paramsName = item.className.substring(0,item.className.length).lowercase()
                            }
                        }
                        //参数名字
                        val paramsNameString = "static const $paramsName = $path;"
                        //transitions
                        val pageTransaction = item.constructorParam["pageTransaction"]
                        val pathRegEx = item.constructorParam["pathRegEx"]
                        val processor = item.constructorParam["processor"]
                        val interceptors = item.constructorParam["onInterceptor"]

                        val registerString = "RRouter.addRoute(\n" +
                                "      NavigatorRoute(\n" +
                                "        $paramsName,\n" +
                                "        (context) =>${
                                    if (item.classParamsList.isEmpty()) {
                                        "const"
                                    } else {
                                        ""
                                    }
                                } ${item.fileName}.${item.className}(${
                                    item.classParamsList
                                        .map {
                                            "${it.name}: ${
                                                it.toGenerateString()
                                            }"
                                        }.toList().joinToString(separator = ",")
                                }),\n" +
                                if (pathRegEx != null) {
                                    "        pathRegEx: ${pathRegEx},\n"
                                } else {
                                    ""
                                } +
                                if (processor != null) {
                                    "        responseProcessor: ${item.fileName}.${processor},\n"
                                } else {
                                    ""
                                } +
                                if (interceptors != null) {
                                    "        interceptors: ${item.fileName}.${interceptors},\n"
                                } else {
                                    ""
                                } +
                                if (pageTransaction != null) {
                                    "        defaultPageTransaction: ${pageTransaction},\n"
                                } else {
                                    ""
                                } +
                                "      ),\n" +
                                "    );"


                        val pathList = item.classParamsList.filter { it.classParamType == PATH }

                        val queryList = item.classParamsList.filter { it.classParamType == QUERY }

                        val bodyList = item.classParamsList.filter { it.classParamType == BODY }

                        val queryAndPathList = mutableListOf<String>()


                        if (queryList.isNotEmpty()) {
                            queryAndPathList.add(
                                "queryParams:{${
                                    queryList.map { it.getMapValue() }.toList().joinToString(separator = ",")
                                }}"
                            )
                        }
                        if (pathList.isNotEmpty()) {
                            queryAndPathList.add(
                                "pathParams:{${
                                    pathList.map { it.getMapValue() }.toList().joinToString(separator = ",")
                                }}"
                            )
                        }

                        val paramsBuilder = StringBuilder()
                        if (queryAndPathList.isNotEmpty()) {
                            paramsBuilder.append(
                                "RRouter.formatPath(${paramsName},${
                                    queryAndPathList.joinToString(
                                        separator = ","
                                    )
                                })"
                            )
                        } else {
                            paramsBuilder.append(paramsName)
                        }

                        val toRoute: String = "static Future<dynamic> to${item.className}(" +
                                "      {${item.getParamsValue()}" +
                                "      bool? replace,\n" +
                                "      bool? clearTrace,\n" +
                                "      bool? isSingleTop,\n" +
                                "      dynamic? result,\n" +
                                "      PageTransitionsBuilder? pageTransitions}) {\n" +
                                "    return RRouter.navigateTo(\n" +
                                "      $paramsBuilder,\n" +
                                if (bodyList.isNotEmpty()) {
                                    "body: {${
                                        bodyList.map {
                                            it.getMapValue()
                                        }.toList()
                                            .joinToString(separator = ",")
                                    }},\n"
                                } else {
                                    ""
                                } +
                                "      replace: replace,\n" +
                                "      clearTrace: clearTrace,\n" +
                                "      isSingleTop: isSingleTop,\n" +
                                "      result: result,\n" +
                                "      pageTransitions: pageTransitions,\n" +
                                "    );\n" +
                                "  }"
                        pageList.add(
                            PageEntity(
                                importStringList.joinToString(separator = "\n"),
                                paramsNameString,
                                registerString,
                                toRoute
                            )
                        )
                    } else if (item.generateType == GenerateType.ERROR) {
                        //导包内容
                        val importString =
                            "import 'package:${pubSpecConfig!!.name}/${item.importName}' as ${item.fileName};"
                        val registerString = "RRouter.setErrorPage(${item.fileName}.${item.className}());"
                        pageList.add(
                            PageEntity(
                                importString, null, registerString, null,
                            )
                        )
                    }
                }
            }
        }
    }
}

data class PageEntity(
    val importString: String,
    val paramsName: String?,
    val registerString: String,
    val toRoute: String?,
)