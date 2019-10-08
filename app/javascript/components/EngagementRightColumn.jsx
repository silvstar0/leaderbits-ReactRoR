import React from 'react';
import PropTypes from 'prop-types';
import EngagementUserCollection from './EngagementUserCollection';

class EngagementRightColumn extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      filterValue: '',
    };
  }

  render() {
    if (this.state.filterValue == '') {
      var filteredUsers = this.props.users;
    } else {
      const matchInput = user => {
        if (
          user.name
            .toLowerCase()
            .indexOf(this.state.filterValue.toLowerCase()) != -1
        ) {
          return true;
        }

        return (
          user.email
            .toLowerCase()
            .indexOf(this.state.filterValue.toLowerCase()) != -1
        );
      };

      var filteredUsers = this.props.users.filter(matchInput);
    }

    return (
      <div>
        <div className="row">
          <div className="input-group" style={{ margin: 0 }}>
            <span className="input-group-label">
              <i className="fa fa-search" />
            </span>

            <input
              value={this.state.filterValue}
              onChange={e => this.setState({ filterValue: e.target.value })}
              className="input-group-field"
              type="text"
              placeholder="Filter list"
              style={{ backgroundColor: 'rgb(247, 247, 247)' }}
            />
          </div>
        </div>

        <EngagementUserCollection users={filteredUsers} />
      </div>
    );
  }
}

export default EngagementRightColumn;
