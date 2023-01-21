package org.sheeper.localchat;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

import com.corundumstudio.socketio.Configuration;
import com.corundumstudio.socketio.SocketConfig;
import com.corundumstudio.socketio.SocketIOServer;

@SpringBootApplication
public class LocalChatApplication {

	@Value("${rt-server.host}")
	private String host;

	@Value("${rt-server.port}")
	private Integer port;

	@Bean
	public SocketIOServer socketIOServer() {
		Configuration config = new Configuration();
		config.setHostname(host);
		config.setPort(port);

		SocketConfig sockConfig = new SocketConfig();
		sockConfig.setReuseAddress(true);
		config.setSocketConfig(sockConfig);

		return new SocketIOServer(config);
	}

	public static void main(String[] args) {
		SpringApplication.run(LocalChatApplication.class, args);
	}

}
