package eu.mlich.lucy.model

import java.time.OffsetDateTime
import javax.persistence.*

@Entity
@Table(name = "instance")
data class Instance(
        @Id
        @GeneratedValue(strategy = GenerationType.IDENTITY)
        @Column(name = "id")
        val id: Int?,

        @Column(name = "auth_token")
        val authToken: String,

        @Column(name = "creation_datetime")
        val creationDatetime: OffsetDateTime
)
