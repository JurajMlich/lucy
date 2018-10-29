package eu.mlich.lucy.rest

import eu.mlich.lucy.dto.InstanceInstructionDto
import eu.mlich.lucy.repository.InstanceRepository
import eu.mlich.lucy.service.InstanceInstructionService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.format.annotation.DateTimeFormat
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController
import java.time.LocalDateTime
import java.time.OffsetDateTime

@RestController()
@RequestMapping(path = ["instructions"])
class InstanceInstructionResource @Autowired constructor(
        val instanceInstructionService: InstanceInstructionService,
        val instanceRepository: InstanceRepository // todo get rid of
) {
    @RequestMapping
    fun findAll(
            @RequestParam(name = "from") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) fromDateTime: LocalDateTime,
            @RequestParam(name = "to") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) toDateTime: LocalDateTime
    ): List<InstanceInstructionDto> {
        return instanceInstructionService.findAllForInstance(instanceRepository.findById(1).get(), fromDateTime, toDateTime).map {
            InstanceInstructionDto(it.id!!, it.type, it.data, it.creationDatetime)
        }
    }
}
