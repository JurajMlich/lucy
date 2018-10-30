package eu.mlich.lucy.dto

import eu.mlich.lucy.model.money.DepositType
import java.util.*
import kotlin.collections.HashSet

data class DepositDto(
        var id: UUID? = null,
        var name: String,
        var balance: Double,
        var disabled: Boolean,
        var type: DepositType,
        var ownersIds: Set<UUID> = HashSet(),
        var accessibleByUsersIds: Set<UUID> = HashSet()
)