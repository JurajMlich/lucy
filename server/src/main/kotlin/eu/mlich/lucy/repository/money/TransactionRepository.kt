package eu.mlich.lucy.repository.money

import eu.mlich.lucy.model.money.Transaction
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.repository.CrudRepository
import org.springframework.stereotype.Repository
import java.util.*

@Repository
interface TransactionRepository : JpaRepository<Transaction, Int> {
    fun findOneByPublicKey(publicKey: UUID): Optional<Transaction>
}