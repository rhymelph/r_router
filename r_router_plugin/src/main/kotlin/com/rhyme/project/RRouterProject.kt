package com.rhyme.project

import com.intellij.openapi.components.ServiceManager
import com.intellij.openapi.project.Project

interface RRouterProject {

    //构建路由绑定
    fun generateRouters()

    companion object {
        fun getInstance(project: Project): RRouterProject {
            return ServiceManager.getService(project, RRouterProject::class.java)
        }
    }
}
