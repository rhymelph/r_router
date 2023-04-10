package com.rhyme.action

import com.intellij.openapi.actionSystem.AnAction
import com.intellij.openapi.actionSystem.AnActionEvent
import com.intellij.openapi.actionSystem.PlatformDataKeys
import com.intellij.openapi.application.runWriteAction
import com.rhyme.notifier.NotifierManager
import com.rhyme.project.RRouterProject
import io.flutter.sdk.FlutterSdk

class BuildRoutersFileAction : AnAction() {

    override fun actionPerformed(e: AnActionEvent) {
        val project = e.getData(PlatformDataKeys.PROJECT) ?: return
        runWriteAction {
            RRouterProject.getInstance(project).generateRouters()
            NotifierManager().notifyInformation("Generate Routers Success!")
        }

    }
}
