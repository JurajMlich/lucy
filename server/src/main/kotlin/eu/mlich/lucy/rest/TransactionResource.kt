package eu.mlich.lucy.rest

import eu.mlich.lucy.dto.TransactionDto
import eu.mlich.lucy.rest.exception.BadRequestException
import eu.mlich.lucy.rest.exception.NotFoundException
import eu.mlich.lucy.service.TransactionService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.data.domain.Pageable
import org.springframework.web.bind.annotation.*
import java.util.*

@RestController
@RequestMapping(path = ["transactions"])
class TransactionResource @Autowired constructor(private val service: TransactionService) {
    @RequestMapping
    fun findAll(pageRequest: Pageable) = service.findAll(pageRequest)

    @RequestMapping(path = ["ids"])
    fun findIds() = service.findAll().map { it.id }

    @RequestMapping(path = ["{publicKey}"])
    fun findOne(
            @PathVariable("publicKey") publicKey: UUID
    ) = service.findOneByPublicKey(publicKey) ?: throw NotFoundException()

    @RequestMapping(method = [RequestMethod.POST])
    fun create(@RequestBody entity: TransactionDto) = service.save(entity)

    @RequestMapping(method = [RequestMethod.PUT], path = ["{publicKey}"])
    fun update(@PathVariable("publicKey") publicKey: UUID, @RequestBody entity: TransactionDto): TransactionDto {
        entity.id = publicKey
        service.save(entity)
        return entity
    }
}
