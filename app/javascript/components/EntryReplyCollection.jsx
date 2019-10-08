import React from 'react';
import PropTypes from 'prop-types';
import LikeEntry from './LikeEntry';
import EntryReplyItem from './EntryReplyItem';
import PrefilledReply from './PrefilledReply';

import EntryUtils from './EntryUtils';

class EntryReplyCollection extends React.Component {
  constructor(props) {
    super(props);

    this.onSubmit = this.onSubmit.bind(this);
    this.replyClicked = this.replyClicked.bind(this);

    this.addReply = this.addReply.bind(this);
    this.updateReply = this.updateReply.bind(this);
    this.removeReply = this.removeReply.bind(this);

    this.addToTextFromPrefilledOption = this.addToTextFromPrefilledOption.bind(
      this
    );

    this.state = {
      content: this.props.content,
      reply: null,
      replies: this.props.replies,
      prefilledReplyChosen: false,
    };
  }

  replyClicked(e) {
    this.setState({ visibleInput: true });
  }

  onSubmit(e) {
    e.preventDefault();

    e.target.setAttribute('disabled', 'disabled');
    e.target.value = 'Sending..';

    fetch('/entry_replies', {
      method: 'post',
      credentials: 'include',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        content: this.state.content,
        entry_id: this.props.entry_id,
      }),
    })
      .then(response => {
        return response.json();
      })
      .then(json => {
        this.addReply(json);
        this.setState({
          content: '',
          visibleInput: false,
        });

        EntryUtils.markEntryAsRead(json.entry_group_id);
      });
  }

  addReply(json) {
    let updatedReplies = [...this.state.replies, json];
    this.setState({ replies: updatedReplies });
  }

  updateReply(json) {
    let updatedReplies = this.state.replies.map(el => {
      if (el.id == json.id) return json;
      return el;
    });

    this.setState({ replies: updatedReplies });
  }

  removeReply(id) {
    const replyIndex = this.state.replies.findIndex(
      awaitingReply => awaitingReply.id == id
    );
    const updatedReplies = [
      ...this.state.replies.slice(0, replyIndex),
      ...this.state.replies.slice(replyIndex + 1),
    ];
    this.setState({ replies: updatedReplies });
  }

  handleChange(e) {
    this.setState({ content: e.target.value });
  }

  addToTextFromPrefilledOption(prefilledText) {
    this.setState({
      content: prefilledText + '\n' + this.state.content,
      prefilledReplyChosen: true,
    });
  }

  render() {
    let entryReplyLinkStyle = this.props.can_toggle_entry_like
      ? { style: { marginLeft: '15px' } }
      : {};
    let sendReplyButtonStyle =
      this.state.content.length == 0 ? { disabled: 'disabled' } : {};

    const prefilledReplies = this.props.prefilled_replies;

    return (
      <div>
        <div
          className="footer text-left"
          style={{ display: 'block', clear: 'both' }}
        >
          <div
            className="actions2"
            style={{
              float: 'none',
              fontSize: '14px',
              clear: 'both',
              width: '100%',
              paddingRight: 0,
            }}
          >
            {this.props.can_toggle_entry_like && (
              <LikeEntry
                liked={this.props.liked_by_current_user}
                entry_group_id={this.props.entry_group_id}
                entry_id={this.props.entry_id}
              />
            )}

            {this.props.can_toggle_entry_like && (
              <a {...entryReplyLinkStyle} onClick={this.replyClicked}>
                Reply
              </a>
            )}

            <div style={{ fontSize: '14px', whiteSpace: 'pre-line' }}>
              {this.props.entry_liked_message}
            </div>
          </div>
        </div>

        {this.state.visibleInput && (
          <div className="text-left" style={{ marginTop: '15px' }}>

            <div className="text-center">
              {this.state.prefilledReplyChosen == false && (
                <div>
                  {prefilledReplies.map((content, index) => (
                    <PrefilledReply
                      key={index}
                      onClick={this.addToTextFromPrefilledOption}
                    >
                      {content}
                    </PrefilledReply>
                  ))}
                </div>
              )}
            </div>

            <div className="text-center">
              {this.state.visibleInput && (
                <font style={{fontSize: '14px'}}>
                  {this.props.user_action}
                </font>
              )}
            </div>

            <textarea
              className="reply_content"
              autoFocus
              rows={7}
              value={this.state.content}
              onChange={e => this.handleChange(e)}
              placeholder={`Replying as ${this.props.current_user}`}
            />
            <input
              type="button"
              {...sendReplyButtonStyle}
              onClick={this.onSubmit}
              className="small primary button"
              value="Send Reply"
            />
          </div>
        )}

        {this.state.replies.map(reply => (
          <div
            className="reply"
            style={{ marginTop: '15px', clear: 'both' }}
            key={reply.id}
          >
            <EntryReplyItem
              key={reply.id}
              addReply={this.addReply}
              updateReply={this.updateReply}
              removeReply={this.removeReply}
              {...reply}
            />
          </div>
        ))}
      </div>
    );
  }
}

EntryReplyCollection.propTypes = {
  content: PropTypes.string.isRequired,

  entry_id: PropTypes.number.isRequired,
  current_user: PropTypes.string.isRequired,
  can_toggle_entry_like: PropTypes.bool.isRequired,
  entry_liked_message: PropTypes.string.isRequired,
  prefilled_replies: PropTypes.array.isRequired,
  liked: PropTypes.bool,
  replies: PropTypes.array.isRequired,
};

export default EntryReplyCollection;
