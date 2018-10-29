package eu.mlich.lucy

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.scheduling.annotation.EnableScheduling
import org.springframework.transaction.annotation.EnableTransactionManagement
import java.time.ZoneOffset.UTC
import java.util.*

@SpringBootApplication
@EnableTransactionManagement
@EnableScheduling
class LucyApplication

fun main(args: Array<String>) {
    TimeZone.setDefault(TimeZone.getTimeZone(UTC))
    runApplication<LucyApplication>(*args)
}

