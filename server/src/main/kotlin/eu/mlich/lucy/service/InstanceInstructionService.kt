package eu.mlich.lucy.service

import com.fasterxml.jackson.databind.ObjectMapper
import eu.mlich.lucy.dto.instructions_data.DeleteDataInstanceInstructionData
import eu.mlich.lucy.dto.instructions_data.RefreshDataInstanceInstructionData
import eu.mlich.lucy.model.InstanceInstruction
import eu.mlich.lucy.model.InstanceInstructionType
import eu.mlich.lucy.repository.InstanceInstructionRepository
import eu.mlich.lucy.repository.InstanceRepository
import eu.mlich.lucy.model.Instance
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import java.time.LocalDateTime
import java.time.OffsetDateTime
import javax.transaction.Transactional

@Service
class InstanceInstructionService @Autowired constructor(
        private val instanceInstructionRepository: InstanceInstructionRepository,
        private val instanceRepository: InstanceRepository,
        private val objectMapper: ObjectMapper
) {
    @Transactional
    fun refreshData(resource: String, identifier: String) {
        instanceRepository.findAll().forEach {
            instanceInstructionRepository.save(InstanceInstruction(
                    type = InstanceInstructionType.REFRESH_DATA,
                    creationDatetime = LocalDateTime.now(),
                    data = objectMapper.writeValueAsString(RefreshDataInstanceInstructionData(resource, identifier)),
                    instance = it
            ))
        }
    }

    @Transactional
    fun deleteData(resource: String, identifier: String) {
        instanceRepository.findAll().forEach {
            instanceInstructionRepository.save(InstanceInstruction(
                    type = InstanceInstructionType.DELETE_DATA,
                    creationDatetime = LocalDateTime.now(),
                    data = objectMapper.writeValueAsString(DeleteDataInstanceInstructionData(resource, identifier)),
                    instance = it
            ))
        }
    }

    @Transactional
    fun findAllForInstance(instance: Instance, from: LocalDateTime, to: LocalDateTime): List<InstanceInstruction> {
        return instanceInstructionRepository.findForInstance(instance, from, to)
    }
}