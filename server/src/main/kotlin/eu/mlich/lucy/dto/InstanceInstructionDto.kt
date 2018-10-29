package eu.mlich.lucy.dto

import eu.mlich.lucy.model.InstanceInstructionType
import java.time.LocalDateTime

data class InstanceInstructionDto(
        val id: Long,
        val type: InstanceInstructionType,
        val data: String,
        val creationDatetime: LocalDateTime
)