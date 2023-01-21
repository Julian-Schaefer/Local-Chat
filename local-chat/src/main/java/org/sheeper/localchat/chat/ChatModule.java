package org.sheeper.localchat.chat;

import com.corundumstudio.socketio.HandshakeData;
import com.corundumstudio.socketio.SocketIONamespace;
import com.corundumstudio.socketio.SocketIOServer;
import com.corundumstudio.socketio.listener.ConnectListener;
import com.corundumstudio.socketio.listener.DataListener;
import com.corundumstudio.socketio.listener.DisconnectListener;

import java.io.IOException;
import java.util.HashMap;
import java.util.UUID;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Component;

@Component
public class ChatModule {

    private static final Logger log = LoggerFactory.getLogger(ChatModule.class);

    private final SocketIOServer server;

    private HashMap<String, UUID> connectedUsers = new HashMap<>();

    @Autowired
    private KafkaTemplate<String, String> kafkaTemplate;

    public ChatModule(SocketIOServer server) {
        this.server = server;
        this.server.addConnectListener(onConnected());
        this.server.addDisconnectListener(onDisconnected());
        this.server.addEventListener("login", LoginMessage.class, onLoginReceived());
        this.server.addEventListener("message", ChatMessage.class, onMessageReceived());
    }

    private DataListener<LoginMessage> onLoginReceived() {
        return (client, loginMessage, ackSender) -> {
            connectedUsers.put(loginMessage.getUserName(), client.getSessionId());
            client.set("userId", loginMessage.getUserName());

            log.debug("Client[{}] - Received chat message '{}'", client.getSessionId().toString(), loginMessage);
            client.sendEvent("reply", "ok");
        };
    }

    private DataListener<ChatMessage> onMessageReceived() {
        return (client, chatMessage, ackSender) -> {
            this.sendMessage("received: " + chatMessage.getMessage());
            if (!client.has("userId")) {
                return;
            }

            log.debug("Client[{}] - Received chat message '{}'", client.getSessionId().toString(), chatMessage);
            client.sendEvent("reply", "ok");
        };
    }

    private ConnectListener onConnected() {
        return client -> {
            HandshakeData handshakeData = client.getHandshakeData();
            log.debug("Client[{}] - Connected to chat module through '{}'", client.getSessionId().toString(),
                    handshakeData.getUrl());
        };
    }

    private DisconnectListener onDisconnected() {
        return client -> {
            if (client.has("userId")) {
                var userId = client.get("userId");
                connectedUsers.remove(userId);
            }

            log.debug("Client[{}] - Disconnected from chat module.", client.getSessionId().toString());
        };
    }

    public void sendMessage(String message) {
        this.kafkaTemplate.send("chat", message);
    }

    @KafkaListener(topics = "chat")
    public void consume(String message) throws IOException {
        log.info(String.format("#### -&gt; Consumed message -&gt; %s", message));
    }
}