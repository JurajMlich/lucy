package eu.mlich.lucy.repository

import eu.mlich.lucy.model.InstanceInstruction
import eu.mlich.lucy.model.Instance
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import org.springframework.transaction.annotation.Transactional

@Repository
interface InstanceInstructionRepository: JpaRepository<InstanceInstruction, Int> {
    @Transactional(readOnly = true)
    fun findByInstanceOrderByCreationDatetime(instance: Instance): List<InstanceInstruction>
}