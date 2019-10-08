import React from 'react';
import PropTypes from 'prop-types';
import Linkify from 'react-linkify';
import LikeReply from './LikeReply';
import EntryUtils from './EntryUtils';

class EntryReplyItem extends React.Component {
  constructor(props) {
    super(props);

    this.replyToReply = this.replyToReply.bind(this);

    this.editReply = this.editReply.bind(this);
    this.deleteReply = this.deleteReply.bind(this);

    this.onEntryReplySubmit = this.onEntryReplySubmit.bind(this);
    this.onReplyToReplySubmit = this.onReplyToReplySubmit.bind(this);

    this.state = {
      ...props,

      reply_to_reply_content: '',
      visibleInput: false,
      visibleReplyToReplyInput: false,
    };
  }

  replyToReply(e) {
    this.setState({
      visibleReplyToReplyInput: true,
      reply_to_reply_content: '',
    });
  }

  editReply(e) {
    this.setState({
      visibleInput: true,
      reply_content: this.state.reply_content,
    });
  }

  onReplyToReplySubmit(e) {
    e.preventDefault();

    e.target.setAttribute('disabled', 'disabled');
    e.target.value = 'Sending..';

    fetch('/entry_replies/', {
      method: 'post',
      credentials: 'include',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        parent_reply_id: this.state.id,
        content: this.state.reply_to_reply_content,
        entry_id: this.props.entry_id,
      }),
    })
      .then(response => {
        return response.json();
      })
      .then(json => {
        this.props.addReply(json);
        this.setState({
          reply_to_reply_content: '',
          visibleReplyToReplyInput: false,
        });

        EntryUtils.markEntryAsRead(json.entry_group_id);
      });
  }

  onEntryReplySubmit(e) {
    e.preventDefault();

    e.target.setAttribute('disabled', 'disabled');
    e.target.value = 'Sending..';

    fetch('/entry_replies/' + this.state.id, {
      method: 'put',
      credentials: 'include',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        content: this.state.reply_content,
        entry_id: this.props.entry_id,
      }),
    })
      .then(response => {
        return response.json();
      })
      .then(json => {
        this.props.updateReply(json);
        this.setState({
          visibleInput: false,
        });
        EntryUtils.markEntryAsRead(json.entry_group_id);
      });
  }

  deleteReply(e) {
    fetch('/entry_replies/' + this.state.id, {
      method: 'delete',
      credentials: 'include',
      headers: { 'Content-Type': 'application/json' },
    }).then(response => {
      this.setState({
        visibleInput: false,
        reply_content: '',
      });

      this.props.removeReply(this.state.id);
    });
  }

  handleEntryReplyChange(e) {
    this.setState({ reply_content: e.target.value });
  }

  handleReplyToReplyChange(e) {
    this.setState({ reply_to_reply_content: e.target.value });
  }

  render() {
    let replyToEntrySubmitDisabledAttribute =
      this.state.reply_content.length == 0 ? { disabled: 'disabled' } : {};
    let replyToReplySubmitDisabledAttribute =
      this.state.reply_to_reply_content.length == 0
        ? { disabled: 'disabled' }
        : {};

    return (
      <div key={this.props.id}>
        {this.state.visibleInput ? (
          <div>
            <div className="text-left" style={{ marginTop: '15px' }}>
              <textarea
                // class is used in specs
                className="reply_content"
                autoFocus
                value={this.state.reply_content}
                rows={7}
                onChange={e => this.handleEntryReplyChange(e)}
                placeholder={`Replying as ${this.props.current_user}`}
              />
              <input
                type="button"
                {...replyToEntrySubmitDisabledAttribute}
                onClick={this.onEntryReplySubmit}
                className="small primary button"
                value="Send Reply"
              />
            </div>
          </div>
        ) : (
          <div>
            <div>
              <div
                id={`entry_reply_${this.props.id}`}
                style={{ backgroundColor: this.props.color }}
                className="content"
              >
                <div>
                  <strong>{this.props.entry_author}</strong>

                  {/*{this.props.parent_reply_id && (*/}
                  {/*<a>In reply to {this.props.parent_reply_id}</a>*/}
                  {/*)}*/}
                </div>
                <Linkify>{this.state.reply_content}</Linkify>
              </div>
              <div style={{ fontSize: '14px', whiteSpace: 'pre-line' }}>
                {this.props.reply_liked_message}
              </div>
            </div>

            <div className="text-left footer" style={{ display: 'block' }}>
              <div className="info2" style={{ fontSize: '14px' }}>
                {this.props.display_time}
                {/*<time className="timeago" data-datetime={this.props.display_time}></time>*/}
              </div>
              <div
                className="actions2"
                style={{ fontSize: '14px', width: '100%' }}
              >
                {this.props.can_like_reply && (
                  <LikeReply
                    liked={this.props.liked_by_current_user}
                    entry_group_id={this.props.entry_group_id}
                    id={this.state.id}
                  />
                )}

                {this.props.can_reply_to_reply && (
                  <a
                    onClick={this.replyToReply}
                    style={{ marginRight: '15px' }}
                  >
                    Reply
                  </a>
                )}

                {this.props.can_edit_reply && <a onClick={this.editReply}>Edit</a>}

                {this.props.can_delete_reply && (
                  <a
                    onClick={() => {
                      if (
                        window.confirm(
                          'Are you sure you wish to delete this reply?'
                        )
                      )
                        this.deleteReply();
                    }}
                    style={{ marginLeft: '15px' }}
                  >
                    Delete
                  </a>
                )}
              </div>
            </div>

            {this.state.visibleReplyToReplyInput && (
              <div>
                <div className="text-left" style={{ marginTop: '30px' }}>
                    <textarea
                      // class is used in specs
                      className="reply_content"
                      autoFocus
                      rows={7}
                      value={this.state.reply_to_reply_content}
                      onChange={e => this.handleReplyToReplyChange(e)}
                      placeholder={`Replying as ${this.props.current_user}`}
                    />
                  <input
                    type="button"
                    {...replyToReplySubmitDisabledAttribute}
                    onClick={this.onReplyToReplySubmit}
                    className="small primary button"
                    value="Send Reply"
                  />
                </div>
              </div>
            )}
          </div>
        )}
      </div>
    );
  }
}

EntryReplyItem.propTypes = {
  entry_id: PropTypes.number.isRequired,
  liked_by_current_user: PropTypes.bool.isRequired,

  can_reply_to_reply: PropTypes.bool.isRequired,
  can_edit_reply: PropTypes.bool.isRequired,
  can_delete_reply: PropTypes.bool.isRequired,

  addReply: PropTypes.func.isRequired,
  updateReply: PropTypes.func.isRequired,
  removeReply: PropTypes.func.isRequired,

  current_user: PropTypes.string.isRequired,
  entry_author: PropTypes.string.isRequired,
  reply_liked_message: PropTypes.string.isRequired,
};

export default EntryReplyItem;
