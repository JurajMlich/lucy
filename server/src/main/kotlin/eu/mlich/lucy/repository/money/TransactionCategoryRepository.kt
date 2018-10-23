package eu.mlich.lucy.repository.money

import eu.mlich.lucy.model.money.TransactionCategory
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.*

@Repository
interface TransactionCategoryRepository : JpaRepository<TransactionCategory, Int> {
    fun findOneByPublicKey(publicKey: UUID): Optional<TransactionCategory>
}