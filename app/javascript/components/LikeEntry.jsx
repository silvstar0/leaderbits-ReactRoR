import React from 'react';
import PropTypes from 'prop-types';
import EntryUtils from './EntryUtils';

class LikeEntry extends React.Component {
  constructor(props) {
    super(props);

    this.likeClicked = this.likeClicked.bind(this);

    this.state = {
      liked: this.props.liked,
    };
  }

  likeClicked(e) {
    fetch(`/entries/${this.props.entry_id}/toggle_like`, {
      method: 'post',
      credentials: 'include',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ id: this.props.entry_id }),
    });

    EntryUtils.markEntryAsRead(this.props.entry_group_id);

    this.setState({
      liked: !this.state.liked,
    });
  }

  render() {
    let likeStyle = this.state.liked
      ? { style: { fontWeight: 'bold', color: '#4A90E2', cursor: 'pointer' } }
      : { style: { cursor: 'pointer' } };

    return (
      <a onClick={this.likeClicked} {...likeStyle}>
        Like
      </a>
    );
  }
}

LikeEntry.propTypes = {
  liked: PropTypes.bool.isRequired,
  entry_group_id: PropTypes.number.isRequired,
  entry_id: PropTypes.number.isRequired,
};

export default LikeEntry;
