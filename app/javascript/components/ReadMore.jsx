import React from 'react';
import PropTypes from 'prop-types';

class ReadMore extends React.Component {
  constructor(props) {
    super(props);
    this.state = { displayBody: false };
  }

  render() {
    return (
      <div>
        {this.props.desc}

        {this.state.displayBody ? (
          <div>
            <a
              onClick={e => this.setState({ displayBody: false })}
              className="button small"
              style={{ margin: '10px 0', cursor: 'pointer' }}
            >
              Hide
            </a>
          </div>
        ) : (
          <div>
            <a
              onClick={e => this.setState({ displayBody: true })}
              className="button small"
              style={{ margin: '10px 0', cursor: 'pointer' }}
            >
              Read
            </a>
          </div>
        )}

        {this.state.displayBody && (
          <div
            onClick={e => this.setState({ displayBody: false })}
            dangerouslySetInnerHTML={{ __html: this.props.body }}
          />
        )}
      </div>
    );
  }
}

ReadMore.propTypes = {
  desc: PropTypes.string.isRequired,
  body: PropTypes.string.isRequired,
};

export default ReadMore;
