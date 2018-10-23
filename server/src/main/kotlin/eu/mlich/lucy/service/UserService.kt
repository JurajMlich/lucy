package eu.mlich.lucy.service

import eu.mlich.lucy.dto.UserDto
import eu.mlich.lucy.model.User
import eu.mlich.lucy.repository.UserRepository
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.data.domain.Pageable
import org.springframework.stereotype.Service
import java.util.*

@Service
class UserService @Autowired constructor(private val repository: UserRepository) {
    companion object {
        const val RESOURCE_NAME = "User"
    }

    fun findAll() = repository.findAll().map { convertToDto(it) }

    fun findAll(pageable: Pageable) = repository.findAll(pageable).map { convertToDto(it) }

    fun findOneById(id: Int): UserDto? {
        return repository.findById(id).map { convertToDto(it) }.orElse(null)
    }

    fun findOneByPublicKey(publicKey: UUID): UserDto? {
        return repository.findOneByPublicKey(publicKey).map { convertToDto(it) }.orElse(null)
    }

    fun convertToDto(entity: User): UserDto {
        return UserDto(entity.publicKey, entity.email, entity.firstName, entity.lastName)
    }
}