package eu.mlich.lucy.repository

import eu.mlich.lucy.model.Instance
import eu.mlich.lucy.model.InstanceInstruction
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param
import org.springframework.stereotype.Repository
import java.time.LocalDateTime
import java.time.OffsetDateTime

@Repository
interface InstanceInstructionRepository : JpaRepository<InstanceInstruction, Int> {
    fun findByInstanceOrderByCreationDatetime(instance: Instance): List<InstanceInstruction>

    @Query("FROM InstanceInstruction WHERE creationDatetime >= :from AND creationDatetime <= :to AND instance = :instance" +
            " ORDER BY creationDatetime")
    fun findForInstance(
            @Param("instance") instance: Instance,
            @Param("from") from: LocalDateTime,
            @Param("to") to: LocalDateTime
    ): List<InstanceInstruction>
}