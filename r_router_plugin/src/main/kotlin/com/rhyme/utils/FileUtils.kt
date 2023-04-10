package com.rhyme.utils

import com.intellij.openapi.project.Project
import com.intellij.openapi.project.guessProjectDir
import com.intellij.openapi.vfs.VirtualFile
import io.flutter.pub.PubRoot
import io.flutter.utils.FlutterModuleUtils
import org.yaml.snakeyaml.Yaml
import java.io.FileInputStream

object FileUtils {

    //获取lib文件
    internal fun getLibDirectory(project: Project): VirtualFile? {
        return PubRoot.forFile(getProjectIdeaFile(project))?.lib
    }

    //获取到router文件夹
    // ../src/router_gen/
    internal fun getRouterDirectory(project: Project): VirtualFile {
        return getLibDirectory(project)?.let {
            return@let (it.findChild("generated") ?: it.createChildDirectory(this, "generated")).run {
                return@run (findChild("r_router")) ?: createChildDirectory(this, "r_router")
            }
        }!!
    }

    internal fun getDirectoryFromRootPath(virtualFile: VirtualFile, name: String): List<String> {
        val viewPath = virtualFile.path
        val splitViewPath = viewPath.split('/')
        val resultPath = mutableListOf<String>()
        var isStart = false
        for (path in splitViewPath) {
            if (isStart) {
                resultPath.add(path)
            }
            if (path == name) {
                isStart = true
            }
        }
        return resultPath
    }


    //获取lib到需要创建文件的路径
    internal fun getLibFromRootPath(virtualFile: VirtualFile): List<String> {
        return getDirectoryFromRootPath(virtualFile, "lib")
    }

    /**
     * 获取项目.idea目录的一个文件
     */
    private fun getProjectIdeaFile(project: Project): VirtualFile? {
        return project.projectFile ?: project.workspaceFile ?: project.guessProjectDir()?.children?.first()
    }

    internal fun getPubSpecConfig(project: Project): PubSpecConfig? {
        PubRoot.forFile(getProjectIdeaFile(project))?.let { pubRoot ->
            FileInputStream(pubRoot.pubspec.path).use { inputStream ->
                (Yaml().load(inputStream) as? Map<String, Any>)?.let { map ->
                    return PubSpecConfig(project, pubRoot, map)
                }
            }
        }
        return null
    }

    private const val PROJECT_NAME = "name"

    data class PubSpecConfig(
        val project: Project,
        val pubRoot: PubRoot,
        val map: Map<String, Any>,
        //项目名称,导包需要
        val name: String = ((if (map[PROJECT_NAME] == "null") null else map[PROJECT_NAME]) ?: project.name).toString(),
        val isFlutterModule: Boolean = FlutterModuleUtils.hasFlutterModule(project)
    )
}


