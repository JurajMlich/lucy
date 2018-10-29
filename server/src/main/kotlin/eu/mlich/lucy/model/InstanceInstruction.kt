package eu.mlich.lucy.model

import java.time.LocalDateTime
import java.time.OffsetDateTime
import javax.persistence.*

@Entity
@Table(name = "instance_instruction")
data class InstanceInstruction(
        @Id
        @GeneratedValue(strategy = GenerationType.IDENTITY)
        @Column(name = "id")
        val id: Long? = null,

        @Column(name = "type")
        @Enumerated(EnumType.STRING)
        val type: InstanceInstructionType,

        @Column(name = "data")
        val data: String,

        @Column(name = "creation_datetime")
        val creationDatetime: LocalDateTime,

        @ManyToOne
        @JoinColumn(name = "instance_id")
        val instance: Instance
)