package eu.mlich.lucy.service

import eu.mlich.lucy.dto.DepositDto
import eu.mlich.lucy.model.money.Deposit
import eu.mlich.lucy.repository.UserRepository
import eu.mlich.lucy.repository.money.DepositRepository
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.data.domain.Pageable
import org.springframework.stereotype.Service
import java.util.*

@Service
class DepositService @Autowired constructor(
        private var repository: DepositRepository,
        private var instanceInstructionService: InstanceInstructionService,
        private var userRepository: UserRepository
) {
    companion object {
        const val RESOURCE_NAME = "deposit"
    }

    fun findAll() = repository.findAll().map { convertToDto(it) }

    fun search(pageRequest: Pageable) = repository.findAll(pageRequest).map { convertToDto(it) }

    fun findOneById(id: Int): DepositDto? {
        return repository.findById(id)
                .map { convertToDto(it) }
                .orElse(null)
    }

    fun findOneByPublicKey(publicKey: UUID): DepositDto? {
        return repository.findOneByPublicKey(publicKey)
                .map { convertToDto(it) }
                .orElse(null)
    }

    fun save(dto: DepositDto): DepositDto {
        val entity = repository.save(convertToEntity(dto))
        dto.id = entity.publicKey
        instanceInstructionService.refreshData(RESOURCE_NAME, entity.id.toString())
        return dto
    }

    fun convertToEntity(dto: DepositDto): Deposit { // todo throws
        val owner = userRepository.findOneByPublicKey(dto.ownerId).orElseThrow { IllegalArgumentException() }
        val accessibleBy = dto.accessibleByUsersIds.map {
            userRepository.findOneByPublicKey(it).orElseThrow { IllegalArgumentException() }
        }.toHashSet()
        val id = dto.id

        if (id != null) {
            val original = repository.findOneByPublicKey(id).orElse(null)

            if (original != null) {
                original.accessibleBy = accessibleBy
                original.balance = dto.balance
                original.disabled = dto.disabled
                original.name = dto.name
                original.owner = owner
                original.type = dto.type
                return original
            }
        }

        return Deposit(null, dto.name, dto.balance, dto.disabled, dto.type, owner, accessibleBy, id ?: UUID.randomUUID())
    }

    fun convertToDto(entity: Deposit): DepositDto {
        return DepositDto(entity.publicKey, entity.name, entity.balance, entity.disabled, entity.type, entity.owner.publicKey, entity.accessibleBy.map { it.publicKey }.toSet())
    }
}