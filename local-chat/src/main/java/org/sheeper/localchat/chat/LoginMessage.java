package org.sheeper.localchat.chat;

public class LoginMessage {

    private String userName;

    public LoginMessage() {
    }

    public LoginMessage(String userName, String message) {
        super();
        this.userName = userName;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }
}
