package eu.mlich.lucy.repository

import eu.mlich.lucy.model.User
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.*

@Repository
interface UserRepository : JpaRepository<User, Int> {
    fun findOneByPublicKey(publicKey: UUID): Optional<User>
}