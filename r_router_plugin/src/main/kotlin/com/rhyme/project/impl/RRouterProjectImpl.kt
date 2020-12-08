package com.rhyme.project.impl

import com.rhyme.project.RRouterProject
import com.intellij.openapi.project.Project
import com.intellij.openapi.vfs.VirtualFile
import com.intellij.psi.PsiDirectory
import com.intellij.psi.PsiFile
import com.intellij.psi.PsiManager
import com.intellij.psi.util.PsiTreeUtil
import com.jetbrains.lang.dart.psi.*
import com.jetbrains.lang.dart.psi.impl.DartVarDeclarationListImpl
import com.rhyme.utils.CodeUtils
import com.rhyme.utils.FileUtils

class RRouterProjectImpl(val mProject: Project) : RRouterProject {
    private var pubSpecConfig: FileUtils.PubSpecConfig? = null
    val pageList: MutableList<PageEntity> = mutableListOf()
    val routerFileName = "r_router_providers.dart"
    val routerMetaName = "RRouterProvider"

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
                pageList.map { it.paramsName },
                pageList.map { it.registerString }
            ).toByteArray()
        )
    }

    //构建所有页面对应的路由
    private fun generatePageEntity(mProject: Project, file: VirtualFile) {
        val childrenList = PsiManager.getInstance(mProject).findDirectory(file)!!.children
        for (children in childrenList) {
            if (children is PsiDirectory) {
                generatePageEntity(mProject, children.virtualFile)
            } else if (children is PsiFile) {
                val dartFile: DartFile = children as DartFile
                val dartClasses = PsiTreeUtil.findChildrenOfAnyType(dartFile, false, DartClassDefinition::class.java)
                for (dartClass in dartClasses) {
                    //页面名字
                    val pageName = dartClass.componentName.text
                    //是否为页面，是否添加RouterMeta
                    var isPage = false
                    val constructorParamMap = mutableMapOf<String, String>()
                    //获取该类下面的元数据
                    if (dartClass.firstChild is DartMetadata) {
                        val metaData = dartClass.firstChild
                        val dartmeta_first = metaData.firstChild
                        if (dartmeta_first.text.equals("@")) {
                            if (routerMetaName == dartmeta_first.nextSibling.text) {
                                isPage = true
                                for (metaParam in metaData.children) {
                                    if (metaParam is DartArguments) {
                                        //获取到参数
                                        var arguments: String = metaParam.text
                                        var i = 0
                                        var currentName: String? = null
                                        while (i < arguments.length) {
                                            val valueParams = metaParam.findElementAt(i)!!.text
                                            if (valueParams != "(" && valueParams != ")" && valueParams.isNotEmpty()&&!valueParams.contains("\n")&&valueParams!="\'"&&valueParams.trim().isNotEmpty()) {
                                                if (currentName == null) {
                                                    val valueLength = valueParams.length
                                                    currentName = valueParams
                                                    constructorParamMap[currentName] = ""
                                                    i += valueLength
                                                } else if (valueParams == ",") {
                                                    currentName = null
                                                    i += valueParams.length
                                                } else if (valueParams.isNotEmpty() && valueParams != ":") {
                                                    val valueLength = valueParams.length
                                                    constructorParamMap[currentName] = "${constructorParamMap[currentName]}$valueParams"
                                                    i += valueLength
                                                }else{
                                                    i+=valueParams.length
                                                }
                                            }else{
                                                i+=valueParams.length
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    if (isPage) {
                        val namePath = FileUtils.getLibFromRootPath(children.virtualFile).joinToString(separator = "/")
                        //导包内容
                        val importString = "import 'package:${pubSpecConfig!!.name}/$namePath';"
                        // 路径
                        val path =if(constructorParamMap["path"]!=null){"${constructorParamMap["path"]}"}else{namePath}
                        //介绍
                        val description = if(constructorParamMap["description"]!=null){"//${constructorParamMap["description"]}\n  "}else{""}
                        //参数名字
                        val paramsName = "${description}static const ${constructorParamMap["paramName"]} = '$path';"
                        //transitions
                        val transitions = if(constructorParamMap["pageTransitions"]!=null){"        routerPageTransitions: ${constructorParamMap["pageTransitions"]}(),\n"}else{""}
                        //type
                        val type = if(constructorParamMap["pageBuilderType"]!=null){"        routerPageBuilderType: ${constructorParamMap["pageBuilderType"]},\n"}else{""}

                        //获取参数
                        val fields: List<DartComponent> = dartClass.fields
                        var paramsString = ""
                        dartClass.constructors
                        for (dc in fields) {
                            val dc_list: DartVarDeclarationListImpl = dc.context as DartVarDeclarationListImpl
                            //获取类型
                            val type = dc_list.varAccessDeclaration.type!!.text

                            val name = dc_list.varAccessDeclaration.componentName.name

                            if (name != null && name != "key" && type != "key") {
                                paramsString += "\n            $name: p != null && p[\"$name\"] != null\n            ? p[\"$name\"] as $type \n            : null,\n"
                            }
                        }

                        val registerString = "RRouter.myRouter.addRouter(\n" +
                                "        path: ${constructorParamMap["paramName"]},\n" +
                                "        routerWidgetBuilder: (p) => $pageName($paramsString),\n$transitions$type" +
                                "    );"
                        pageList.add(
                            PageEntity(
                                importString, paramsString, paramsName, registerString
                            )
                        )
                    }

                }
            }
        }
    }

    data class PageEntity(
        val importString: String,
        val paramsString: String,
        val paramsName: String,
        val registerString: String
    )
}
