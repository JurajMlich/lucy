package eu.mlich.lucy.dto

import eu.mlich.lucy.model.money.TransactionState
import java.time.OffsetDateTime
import java.util.*

/**
 * @author Juraj Mlich <jurajmlich@gmail.com>
 */
data class TransactionDto(
        var id: UUID? = null,
        var sourceDepositId: UUID?,
        var targetDepositId: UUID,
        var state: TransactionState,
        var value: Double,
        var executionDatetime: OffsetDateTime?,
        val creatorId: UUID,
        var name: String? = null,
        var note: String? = null,
        var categoriesIds: Set<UUID> = HashSet()
)