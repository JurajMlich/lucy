package eu.mlich.lucy.repository.money

import eu.mlich.lucy.model.money.Deposit
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.repository.CrudRepository
import org.springframework.stereotype.Repository
import java.util.*

@Repository
interface DepositRepository: JpaRepository<Deposit, Int> {
    fun findOneByPublicKey(publicKey: UUID): Optional<Deposit>
}