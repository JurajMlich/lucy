package eu.mlich.lucy.dto

import eu.mlich.lucy.model.money.DepositType
import java.util.*

data class DepositDto(
        var id: UUID? = null,
        var name: String,
        var balance: Double,
        var disabled: Boolean,
        var type: DepositType,
        var ownerId: UUID,
        var accessibleByUsersIds: Set<UUID> = HashSet()
)