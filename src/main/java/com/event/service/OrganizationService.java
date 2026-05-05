package com.event.service;

import com.event.dao.OrganizationDAO;
import com.event.model.Organization;

public class OrganizationService {

    private OrganizationDAO dao = new OrganizationDAO();

    public boolean create(Organization org) {
        return dao.createOrganization(org);
    }

    public Integer getOrgByAdmin(int userId) {
        return dao.getOrganizationIdByAdmin(userId);
    }

    public String getOrgNameById(int orgId) {
        return dao.getOrgNameById(orgId);
    }
}