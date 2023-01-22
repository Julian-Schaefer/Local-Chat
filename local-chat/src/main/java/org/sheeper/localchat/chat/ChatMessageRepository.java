package org.sheeper.localchat.chat;

import java.time.Instant;

import org.springframework.data.cassandra.repository.CassandraRepository;

public interface ChatMessageRepository extends CassandraRepository<ChatMessage, String> {
    ChatMessage findByReceiverAndDateTime(String receiver, Instant dateTime);
}
