package eu.mlich.lucy.model.money

import eu.mlich.lucy.model.User
import java.time.OffsetDateTime
import java.util.*
import javax.persistence.*

/**
 * Represent a transaction between a [Deposit] or anything external.
 *
 * @author Juraj Mlich <jurajmlich@gmail.com>
 */
@Entity
@Table(name = "transaction")
data class Transaction(
        @Id
        @GeneratedValue(strategy = GenerationType.IDENTITY)
        @Column(name = "id")
        var id: Int? = null,

        /**
         * Originating deposit. Can be null in case it is external entity that is not managed by the application.
         */
        @ManyToOne
        @JoinColumn(name = "source_deposit_id")
        var sourceDeposit: Deposit?,

        @ManyToOne
        @JoinColumn(name = "target_deposit_id")
        var targetDeposit: Deposit,

        @Column(name = "state")
        @Enumerated(EnumType.STRING)
        var state: TransactionState,

        @Column(name = "value")
        var value: Double,

        @Column(name = "execution_datetime")
        var executionDatetime: OffsetDateTime?,

        @ManyToOne
        @JoinColumn(name = "creator_id")
        val creator: User,

        @Column(name = "name")
        var name: String? = null,

        @Column(name = "note")
        var note: String? = null,

        @ManyToMany
        @JoinTable(
                name = "transaction_transaction_category",
                joinColumns = [JoinColumn(name = "transaction_id")],
                inverseJoinColumns = [(JoinColumn(name = "transaction_category_id"))]
        )
        var categories: Set<TransactionCategory> = HashSet(),

        @Column(name = "public_key")
        var publicKey: UUID = UUID.randomUUID()

) {
        override fun equals(other: Any?) = other is Transaction && other.publicKey === publicKey

        override fun hashCode(): Int = publicKey.hashCode()
}
