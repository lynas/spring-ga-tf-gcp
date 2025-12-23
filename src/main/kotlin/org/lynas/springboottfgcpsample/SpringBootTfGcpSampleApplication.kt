package org.lynas.springboottfgcpsample

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController

@SpringBootApplication
class SpringBootTfGcpSampleApplication

fun main(args: Array<String>) {
    runApplication<SpringBootTfGcpSampleApplication>(*args)
}

@RestController
class SampleController {
    @GetMapping("/")
    fun hello(): String {
        return "Hello World!"
    }
}