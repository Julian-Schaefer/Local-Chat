package org.sheeper.localchat.chat;

public class ChatMessage {

    private String receiver;
    private String message;

    public ChatMessage() {
    }

    public ChatMessage(String receiver, String message) {
        super();
        this.receiver = receiver;
        this.message = message;
    }

    public String getReveicer() {
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
                "receiver='" + receiver + '\'' +
                ", message='" + message + '\'' +
                '}';
    }
}