package org.sheeper.localchat;

import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import com.corundumstudio.socketio.SocketIOServer;

@Component
public class SocketIOServerCommandLineRunner implements CommandLineRunner {

    private final SocketIOServer server;

    public SocketIOServerCommandLineRunner(SocketIOServer server) {
        this.server = server;
    }

    @Override
    public void run(String... args) throws Exception {
        server.start();
    }

}
