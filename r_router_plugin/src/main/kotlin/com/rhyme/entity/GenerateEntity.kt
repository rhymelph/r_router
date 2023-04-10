package com.rhyme.entity

import com.rhyme.entity.GenerateClassParamsType.*
import java.lang.StringBuilder


enum class GenerateType {
    PAGE,
    ERROR,
}

enum class GenerateClassParamsType {
    QUERY,
    BODY,
    PATH,
}


data class GenerateEntity(
    val fileName: String,
    val importName: String,
    val className: String,
    val constructorParam: Map<String, String>,
    val generateType: GenerateType,
    val classParamsList: List<GenerateClassParamEntity>
) {

    fun getParamsValue(): String {
        return classParamsList
            .map {
                "${if(!it.type.endsWith("?")){"required "}else{""}}${it.type} ${it.name}"
            }.toList().joinToString(
                separator = ",",
                postfix = if (classParamsList.isNotEmpty()) {
                    ","
                } else {
                    ""
                }
            )
    }
}


data class GenerateClassParamEntity(
    val name: String,
    val virtualName: String,
    val type: String,
    val classParamType: GenerateClassParamsType,
    val def: String?,
    val typeImport:String?,
) {


    fun getMapValue(): String {
        return "\"${virtualName.replace("\'", "").replace("\"", "")}\":${name}"
    }

    fun toGenerateString(): String {
        val builder = StringBuilder()

        when (classParamType) {
            QUERY -> {
                builder.append("context.queryParams")
                if (type.startsWith("String")) {
                    builder.append(".get")
                } else if (type.startsWith("bool")) {
                    builder.append(".getBool")
                } else if (type.startsWith("num")) {
                    builder.append(".getNum")
                } else if (type.startsWith("double")) {
                    builder.append(".getDouble")
                } else if (type.startsWith("int")) {
                    builder.append(".getInt")
                } else if (type.startsWith("DateTime")) {
                    builder.append(".getDateTime")
                } else if (type.startsWith("List<String>") ||
                    type.startsWith("List<int>") ||
                    type.startsWith("List<double>") ||
                    type.startsWith("List<num>") ||
                    type.startsWith("List<DateTime>") ||
                    type.startsWith("List<bool>")
                ) {
                    builder.append(".getList")
                } else {
                    builder.append(".getEntity<${type}>");
                }
                builder.append("('${name}',${def ?: ""})")
            }

            BODY -> {
                builder.append("context.body")
                builder.append(
                    "['${name}'${
                        if (def == null) {
                            ""
                        } else {
                            ","
                        }
                    }${def ?: ""}]  as $type"
                )
            }

            PATH -> {
                builder.append("context.pathParams")
                if (type.startsWith("String")) {
                    builder.append(".get")
                } else if (type.startsWith("bool")) {
                    builder.append(".getBool")
                } else if (type.startsWith("num")) {
                    builder.append(".getNum")
                } else if (type.startsWith("double")) {
                    builder.append(".getDouble")
                } else if (type.startsWith("int")) {
                    builder.append(".getInt")
                } else if (type.startsWith("DateTime")) {
                    builder.append(".getDateTime")
                } else if (type.startsWith("List<String>") ||
                    type.startsWith("List<int>") ||
                    type.startsWith("List<double>") ||
                    type.startsWith("List<num>") ||
                    type.startsWith("List<DateTime>") ||
                    type.startsWith("List<bool>")
                ) {
                    builder.append(".getList")
                } else {
                    builder.append(".getEntity<${type}>");
                }
                builder.append("('${name}',${def ?: ""})")
            }
        }

        return builder.toString()
    }
}