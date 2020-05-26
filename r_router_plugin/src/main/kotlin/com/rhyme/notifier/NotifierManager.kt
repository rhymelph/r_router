package com.rhyme.notifier

import com.intellij.notification.Notification
import com.intellij.notification.NotificationDisplayType
import com.intellij.notification.NotificationGroup
import com.intellij.notification.NotificationType
import com.intellij.openapi.project.Project

class NotifierManager {
    private val group = NotificationGroup("RRouter Plugin", NotificationDisplayType.STICKY_BALLOON, true)

    fun notifyError(content: String): Notification {
        return notify(null, content, NotificationType.ERROR)
    }

    fun notifyInformation(content: String): Notification {
        return notify(null, content, NotificationType.INFORMATION)
    }

    fun notifyWarning(content: String): Notification {
        return notify(null, content, NotificationType.WARNING)
    }


    fun notifyByType(content: String, type: NotificationType): Notification {
        return notify(null, content, type)
    }

    fun notify(project: Project?, content: String, type: NotificationType): Notification {
        val notification = group.createNotification(content,type)
        notification.notify(project)
        return notification
    }
}