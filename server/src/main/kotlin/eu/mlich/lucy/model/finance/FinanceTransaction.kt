package eu.mlich.lucy.model.finance

import eu.mlich.lucy.model.User
import java.time.LocalDateTime
import java.util.*
import javax.persistence.*

/**
 * Represent a transaction between a [FinanceDeposit] or anything external.
 *
 * @author Juraj Mlich <jurajmlich@gmail.com>
 */
@Entity
@Table(name = "finance_transaction")
data class FinanceTransaction(
        @Id
        @GeneratedValue(strategy = GenerationType.IDENTITY)
        @Column(name = "id")
        var id: Int? = null,

        /**
         * Originating deposit. Can be null in case it is external entity that is not managed by the application.
         */
        @ManyToOne
        @JoinColumn(name = "source_deposit_id")
        var sourceDeposit: FinanceDeposit?,

        @ManyToOne
        @JoinColumn(name = "target_deposit_id")
        var targetDeposit: FinanceDeposit?,

        @Column(name = "state")
        @Enumerated(EnumType.STRING)
        var state: FinanceTransactionState,

        @Column(name = "value")
        var value: Double,

        @Column(name = "execution_datetime")
        var executionDatetime: LocalDateTime?,

        @ManyToOne
        @JoinColumn(name = "creator_id")
        val creator: User,

        @Column(name = "name")
        var name: String? = null,

        @Column(name = "note")
        var note: String? = null,

        @ManyToMany
        @JoinTable(
                name = "finance_transaction_transaction_category",
                joinColumns = [JoinColumn(name = "transaction_id")],
                inverseJoinColumns = [(JoinColumn(name = "transaction_category_id"))]
        )
        var categories: Set<FinanceTransactionCategory> = HashSet(),

        @Column(name = "public_key")
        var publicKey: UUID = UUID.randomUUID()

) {
        override fun equals(other: Any?) = other is FinanceTransaction && other.publicKey === publicKey

        override fun hashCode(): Int = publicKey.hashCode()
}
