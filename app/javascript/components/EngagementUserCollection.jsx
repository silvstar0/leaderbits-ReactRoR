import React from 'react';
import PropTypes from 'prop-types';

class EngagementUserItem extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    const profileHref = `/users/${this.props.uuid}`;

    const rowStyle = this.props.focused
      ? { padding: '15px 0', backgroundColor: 'rgb(217, 235, 255)' }
      : { backgroundColor: '#F7F7F7', padding: '15px 0' };

    return (
      <div className="row" data-equalizer={this.props.id} style={rowStyle}>
        <div
          className="small-3"
          data-equalizer-watch={this.props.id}
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            height: '54px',
          }}
        >
          <div style={{ width: '35px', justifyContent: 'space-around' }}>
            <span title="Momentum">{this.props.momentum}</span>
            <div
              style={{
                width: '100%',
                backgroundColor: '#9013F3',
                height: '3px',
                marginTop: '4px',
              }}
            />
          </div>
        </div>
        <div
          className="small-9 text-left"
          data-equalizer-watch={this.props.id}
          style={{ height: '54px' }}
        >
          <div>
            <font
              style={{
                fontSize: '20px',
                display: 'inline-block',
                fontWeight: '400',
                verticalAlign: 'middle',
              }}
            >
              {this.props.name}
            </font>
          </div>
          <div>
            <a href={profileHref}>view profile</a>&nbsp;|&nbsp;
            {this.props.focused ? (
              <a href={this.props.focusedPath}>focused</a>
            ) : (
              <a href={this.props.focusPath}>focus</a>
            )}
          </div>
        </div>
      </div>
    );
  }
}

EngagementUserItem.propTypes = {
  id: PropTypes.number.isRequired,
  name: PropTypes.string.isRequired,
  email: PropTypes.string.isRequired,
  uuid: PropTypes.string.isRequired,
  momentum: PropTypes.string.isRequired,
  focused: PropTypes.bool.isRequired,
  focusPath: PropTypes.string.isRequired,
  focusedPath: PropTypes.string.isRequired,
};

class EngagementUserCollection extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (
      <div>
        {this.props.users.map(user => (
          <EngagementUserItem key={user.id} {...user} />
        ))}
      </div>
    );
  }
}

EngagementUserCollection.propTypes = {
  users: PropTypes.array.isRequired,
};

export default EngagementUserCollection;
