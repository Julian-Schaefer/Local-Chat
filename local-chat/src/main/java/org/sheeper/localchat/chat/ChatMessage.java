package org.sheeper.localchat.chat;

import java.time.Instant;

import org.springframework.data.cassandra.core.cql.PrimaryKeyType;
import org.springframework.data.cassandra.core.mapping.Column;
import org.springframework.data.cassandra.core.mapping.PrimaryKeyColumn;
import org.springframework.data.cassandra.core.mapping.Table;

@Table
public class ChatMessage {

    @Column
    private String sender;

    @PrimaryKeyColumn(type = PrimaryKeyType.PARTITIONED)
    private String receiver;

    @PrimaryKeyColumn(type = PrimaryKeyType.CLUSTERED)
    private Instant dateTime;

    @Column
    private String message;

    public ChatMessage() {
    }

    public ChatMessage(String sender, String receiver, String message) {
        super();
        this.sender = sender;
        this.receiver = receiver;
        this.message = message;
    }

    public Instant getDateTime() {
        return dateTime;
    }

    public void setDateTime(Instant dateTime) {
        this.dateTime = dateTime;
    }

    public String getSender() {
        return sender;
    }

    public void setSender(String sender) {
        this.sender = sender;
    }

    public String getReceiver() {
        return receiver;
    }

    public void setReceiver(String receiver) {
        this.receiver = receiver;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    @Override
    public String toString() {
        return "ChatMessage{" +
                "sender='" + sender + '\'' +
                ", receiver='" + receiver + '\'' +
                ", message='" + message + '\'' +
                '}';
    }
}