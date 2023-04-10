package com.rhyme.utils

import com.intellij.psi.PsiElement
import com.jetbrains.lang.dart.psi.*
import com.jetbrains.lang.dart.psi.impl.DartCallExpressionImpl
import com.rhyme.entity.MetaData

object SourceUtils {
    /**
     * 获取方法里面的参数元数据
     *
     * @param simpleParameter dart 组件
     */
    internal fun getMethodParamsMeta(simpleParameter: DartSimpleFormalParameter): MetaData {
        var metaName = ""
        val constructorParamMap = mutableMapOf<String, String>()
        if (simpleParameter.firstChild is DartMetadata) {
            val metaData = simpleParameter.firstChild
            val dartmetaFirst = metaData.firstChild
            if (dartmetaFirst.text == "@") {
                metaName = dartmetaFirst.nextSibling.text
                constructorParamMap.putAll(getMetaArguments(metaData))
            }
        }
        return MetaData(metaName, constructorParamMap)
    }

    /**
     * 获取方法/成员变量的元数据
     *
     * @param dartComponent dart 组件
     */
    internal fun getComponentMeta(dartComponent: DartComponent): MetaData {
        var metaName = ""
        val constructorParamMap = mutableMapOf<String, String>()
        if (dartComponent.firstChild is DartMetadata) {
            val metaData = dartComponent.firstChild
            val dartmetaFirst = metaData.firstChild
            if (dartmetaFirst.text == "@") {
                metaName = dartmetaFirst.nextSibling.text
                constructorParamMap.putAll(getMetaArguments(metaData))
            }
        }
        return MetaData(metaName, constructorParamMap)
    }

    /**
     * 获取类的数据
     *
     * @param dartClass 类
     */
    internal fun getMetaData(dartClass: DartClassDefinition): MetaData {
        var metaName = ""
        val constructorParamMap = mutableMapOf<String, String>()
        if (dartClass.firstChild is DartMetadata) {
            val metaData = dartClass.firstChild
            val dartMetaFirst = metaData.firstChild
            if (dartMetaFirst.text == "@") {
                metaName = dartMetaFirst.nextSibling.text
                constructorParamMap.putAll(getMetaArguments(metaData))
            }
        }
        return MetaData(metaName, constructorParamMap)
    }

    internal fun getMetaDate(varDeclaration: DartVarAccessDeclaration): List<MetaData> {
        val list = mutableListOf<MetaData>()
        for (varItem in varDeclaration.metadataList) {
            val dartMetaFirst = varItem.firstChild
            if (dartMetaFirst.text == "@") {
                val metaName = dartMetaFirst.nextSibling.text
                val constructorParamMap = mutableMapOf<String, String>()
                constructorParamMap.putAll(getMetaArguments(varItem))
                list.add(MetaData(metaName, constructorParamMap))
            }
        }
        return list
    }

    /**
     * 获取元数据中的参数
     *
     * @param metaData 元数据
     */
    private fun getMetaArguments(metaData: PsiElement): MutableMap<String, String> {
        val constructorParamMap = mutableMapOf<String, String>()
        for (metaParam in metaData.children) {
            if (metaParam is DartArguments) {
                //获取到参数
                if(metaParam.argumentList != null){
                    for(argument in metaParam.argumentList!!.namedArgumentList){
                        val nameExpression = argument.parameterReferenceExpression
                        val child = nameExpression.firstChild
                        constructorParamMap[child.text] = argument.expression.text
                    }
                }
            }
        }
        return constructorParamMap
    }
}