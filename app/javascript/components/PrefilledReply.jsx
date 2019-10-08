import React from 'react';
import PropTypes from 'prop-types';

class PrefilledReply extends React.Component {
  constructor(props) {
    super(props);

    //this.clicked = this.clicked.bind(this);
  }

  render() {
    return (
      <span>
        <a
          onClick={e => this.props.onClick(e.target.innerHTML)}
          className="button"
          style={{marginBottom: '5px'}}
        >
          {this.props.children}
        </a>&nbsp;
      </span>
    );
  }
}

PrefilledReply.propTypes = {
  onClick: PropTypes.func.isRequired,
};

export default PrefilledReply;
