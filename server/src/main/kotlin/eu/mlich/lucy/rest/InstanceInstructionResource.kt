package eu.mlich.lucy.rest

import eu.mlich.lucy.dto.InstanceInstructionDto
import eu.mlich.lucy.repository.InstanceRepository
import eu.mlich.lucy.service.InstanceInstructionService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController()
@RequestMapping(path = ["instructions"])
class InstanceInstructionResource @Autowired constructor(
        val instanceInstructionService: InstanceInstructionService,
        val instanceRepository: InstanceRepository // todo get rid of
) {
    @RequestMapping
    fun findAll(): List<InstanceInstructionDto> {
        return instanceInstructionService.findAllForInstance(instanceRepository.findById(1).get()).map {
            InstanceInstructionDto(it.id!!, it.type, it.data, it.creationDatetime)
        }
    }
}
