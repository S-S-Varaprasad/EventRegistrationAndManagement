package com.event.service;

import com.event.dao.UserDAO;
import com.event.model.User;
import com.event.util.PasswordUtil;

public class UserService {

    private UserDAO dao = new UserDAO();

    // LOGIN: hash password first, then check DB
    public User login(String email, String password) {
        String hashedPassword = PasswordUtil.hashPassword(password);
        return dao.login(email, hashedPassword);
    }

    // REGISTER: hash password before storing
    public boolean register(User user) {
        String hashedPassword = PasswordUtil.hashPassword(user.getPasswordHash());
        user.setPasswordHash(hashedPassword);
        return dao.registerUser(user);
    }
}