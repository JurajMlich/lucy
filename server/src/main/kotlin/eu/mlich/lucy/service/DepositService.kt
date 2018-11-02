package eu.mlich.lucy.service

import eu.mlich.lucy.dto.FinanceDepositDto
import eu.mlich.lucy.model.finance.FinanceDeposit
import eu.mlich.lucy.repository.UserRepository
import eu.mlich.lucy.repository.finance.FinanceDepositRepository
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.data.domain.Pageable
import org.springframework.stereotype.Service
import java.util.*

@Service
class DepositService @Autowired constructor(
        private var repository: FinanceDepositRepository,
        private var instanceInstructionService: InstanceInstructionService,
        private var userRepository: UserRepository
) {
    companion object {
        const val RESOURCE_NAME = "deposit"
    }

    fun findAll() = repository.findAll().map { convertToDto(it) }

    fun search(pageRequest: Pageable) = repository.findAll(pageRequest).map { convertToDto(it) }

    fun findOneById(id: Int): FinanceDepositDto? {
        return repository.findById(id)
                .map { convertToDto(it) }
                .orElse(null)
    }

    fun findOneByPublicKey(publicKey: UUID): FinanceDepositDto? {
        return repository.findOneByPublicKey(publicKey)
                .map { convertToDto(it) }
                .orElse(null)
    }

    fun save(dto: FinanceDepositDto): FinanceDepositDto {
        val entity = repository.save(convertToEntity(dto))
        dto.id = entity.publicKey
        instanceInstructionService.refreshData(RESOURCE_NAME, entity.publicKey.toString())
        return dto
    }

    fun convertToEntity(dto: FinanceDepositDto): FinanceDeposit { // todo throws
        val owners = dto.ownersIds.map {
            userRepository.findOneByPublicKey(it).orElseThrow { IllegalArgumentException() }
        }.toHashSet()
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
                original.owners = owners
                original.type = dto.type
                original.minBalance = dto.minBalance
                return original
            }
        }

        return FinanceDeposit(null, dto.name, dto.balance, dto.disabled, dto.minBalance, dto.type, owners, accessibleBy, id ?: UUID.randomUUID())
    }

    fun convertToDto(entity: FinanceDeposit): FinanceDepositDto {
        return FinanceDepositDto(entity.publicKey, entity.name, entity.balance, entity.disabled, entity.minBalance, entity.type, entity.owners.map { it.publicKey }.toSet(), entity.accessibleBy.map { it.publicKey }.toSet())
    }
}