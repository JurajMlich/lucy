package eu.mlich.lucy.rest

import eu.mlich.lucy.rest.exception.NotFoundException
import eu.mlich.lucy.service.UserService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.data.domain.Pageable
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import java.util.*

@RestController()
@RequestMapping(path = ["users"])
class UserResource @Autowired constructor(var service: UserService) {
    @RequestMapping
    fun findAll(pageRequest: Pageable) = service.findAll(pageRequest)

    @RequestMapping(path = ["ids"])
    fun findIds() = service.findAll().map { it.id }

    @RequestMapping(path = ["{publicKey}"])
    fun findOne(
            @PathVariable("publicKey") publicId: UUID
    ) = service.findOneByPublicKey(publicId) ?: throw NotFoundException()
}
