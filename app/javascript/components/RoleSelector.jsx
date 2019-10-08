import React from 'react';
import PropTypes from 'prop-types';

class TeamRoleItem extends React.Component {
  constructor(props) {
    super(props);

    this.onDelete = this.props.onTeamRoleDelete;
  }

  render() {
    return (
      <tr>
        <td>
          <strong>{this.props.role_name}</strong>
        </td>
        <td>
          <strong>{this.props.team_name}</strong>
        </td>
        <td>
          <a
            onClick={this.onDelete.bind(null, this.props)}
            alt="Delete"
            className="destroy"
          >
            Delete
          </a>
        </td>
      </tr>
    );
  }
}

TeamRoleItem.propTypes = {
  role_id: PropTypes.any.isRequired,
  team_id: PropTypes.any.isRequired,
  role_name: PropTypes.any.isRequired,
  team_name: PropTypes.any.isRequired,
  onTeamRoleDelete: PropTypes.func.isRequired,
};

class RoleSelector extends React.Component {
  constructor(props) {
    super(props);

    this.onRoleChange = this.onRoleChange.bind(this);
    this.onTeamChange = this.onTeamChange.bind(this);
    this.onAddRole = this.onAddRole.bind(this);

    this.onTeamRoleDelete = this.onTeamRoleDelete.bind(this);

    let teamsRoles =
      this.props.initial_teams_roles.length > 0
        ? JSON.parse(this.props.initial_teams_roles)
        : [];

    this.state = {
      teamsRoles: teamsRoles,
      newRole: {
        role_id: this.props.roles[0].id,
        role_name: this.props.roles[0].name,
        team_id: this.props.teams[0].id,
        team_name: this.props.teams[0].name,
      },
    };
  }

  firstOptionsAsDefault(excludeTeamsRoles) {
    const excludeTeamIds = excludeTeamsRoles.map(teamRole =>
      parseInt(teamRole.team_id, 10)
    );
    const availableTeams = this.props.teams.filter(
      team => !excludeTeamIds.includes(team.id)
    );

    if (availableTeams.length == 0) {
      return null;
    }

    return {
      role_id: this.props.roles[0].id,
      role_name: this.props.roles[0].name,
      team_id: availableTeams[0].id,
      team_name: availableTeams[0].name,
    };
  }

  onTeamRoleDelete(childData, e) {
    const teamRoleIndex = this.state.teamsRoles.findIndex(
      teamRole =>
        teamRole.role_id == childData.role_id &&
        teamRole.team_id == childData.team_id
    );
    const cleanTeamsRoles = [
      ...this.state.teamsRoles.slice(0, teamRoleIndex),
      ...this.state.teamsRoles.slice(teamRoleIndex + 1),
    ];
    this.setState({ teamsRoles: cleanTeamsRoles });

    this.setState({ newRole: this.firstOptionsAsDefault(cleanTeamsRoles) });
    return false;
  }

  onRoleChange(e) {
    let newRole = this.state.newRole;

    let updatedNewRole = {};
    Object.assign(updatedNewRole, newRole, {
      role_id: e.target.value,
      role_name: e.target.options[e.target.selectedIndex].innerText,
    });

    this.setState({ newRole: updatedNewRole });
  }

  onTeamChange(e) {
    let newRole = this.state.newRole;

    let updatedNewRole = {};
    Object.assign(updatedNewRole, newRole, {
      team_id: e.target.value,
      team_name: e.target.options[e.target.selectedIndex].innerText,
    });

    this.setState({ newRole: updatedNewRole });
  }

  onAddRole(e) {
    let newTeamsRoles = [...this.state.teamsRoles, this.state.newRole];
    this.setState({
      teamsRoles: newTeamsRoles,
      newRole: this.firstOptionsAsDefault(newTeamsRoles),
    });
  }

  render() {
    const excludeTeamIds = this.state.teamsRoles.map(teamRole =>
      parseInt(teamRole.team_id, 10)
    );
    const availableTeams = this.props.teams.filter(
      team => !excludeTeamIds.includes(team.id)
    );

    return (
      <div>
        <input
          name="user[role]"
          type="hidden"
          value={JSON.stringify(this.state.teamsRoles)}
        />
        <fieldset className="fieldset">
          <legend>Abilities</legend>
          <div>
            <table className="unstriped">
              <thead>
                <tr>
                  <th width="33%">
                    {availableTeams.length > 0 ? (
                      <div>
                        <legend htmlFor="role-selector">Role</legend>
                        <select
                          value={this.state.newRole.role_id}
                          onChange={this.onRoleChange}
                          id="role-selector"
                          style={{ width: 'auto' }}
                        >
                          <option key="role-0" />
                          {this.props.roles.map(role => (
                            <option key={role.id} value={role.id}>
                              {role.name}
                            </option>
                          ))}
                        </select>
                      </div>
                    ) : (
                      <div>
                        <legend htmlFor="role-selector">Role</legend>
                      </div>
                    )}
                  </th>
                  <th width="33%">
                    {availableTeams.length > 0 ? (
                      <div>
                        <legend htmlFor="team-selector">Team</legend>
                        <select
                          value={this.state.newRole.team_id}
                          onChange={this.onTeamChange}
                          id="team-selector"
                          style={{ width: 'auto' }}
                        >
                          <option key="team-0" />
                          {availableTeams.map(team => (
                            <option key={team.id} value={team.id}>
                              {team.name}
                            </option>
                          ))}
                        </select>
                      </div>
                    ) : (
                      <div>
                        <legend htmlFor="team-selector">Team</legend>
                      </div>
                    )}
                  </th>
                  <th width="33%">
                    {availableTeams.length > 0 ? (
                      <div>
                        {this.state.newRole &&
                          this.state.newRole.team_id &&
                          this.state.newRole.role_id && (
                            <button
                              type="button"
                              className="button"
                              onClick={this.onAddRole}
                              style={{ float: 'left', margin: 0 }}
                            >
                              Add role
                            </button>
                          )}
                      </div>
                    ) : (
                      <div />
                    )}
                  </th>
                </tr>
              </thead>
              <tbody>
                {this.state.teamsRoles.map(teamRole => (
                  <TeamRoleItem
                    key={teamRole.team_id}
                    {...teamRole}
                    onTeamRoleDelete={this.onTeamRoleDelete}
                  />
                ))}
              </tbody>
            </table>
          </div>
        </fieldset>
      </div>
    );
  }
}

RoleSelector.propTypes = {
  roles: PropTypes.array.isRequired,
  teams: PropTypes.array.isRequired,
  initial_teams_roles: PropTypes.any.isRequired,
};

export default RoleSelector;
