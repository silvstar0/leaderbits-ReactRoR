import React from 'react';
import PropTypes from 'prop-types';

import Select from 'react-select';

class EntryVisibilitySelector extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      selectedLabels: this.props.selectedLabels,
      hiddenInputValueCSV: this.props.selectedLabels.join(','),
    };
  }

  render() {
    //const allLabels = ["My Mentors", "In whole LeaderBits Community(anonymously)", "My Peers"];

    const defaultOptions = this.props.allLabels.map(title => ({
      value: title,
      label: title,
    }));

    //defaultValue={[defaultOptions[0], defaultOptions[2], defaultOptions[1]]}

    const defaultValue = this.state.selectedLabels.map(title => ({
      value: title,
      label: title
    }))

    //console.log(this.props.selectedLabels);
    return (
      <div id="EntryVisibilitySelector">
        <Select
          isMulti
          defaultValue={defaultValue}
          onChange={this.handleChange}
          options={defaultOptions}
        />
        <input
          type="hidden"
          name={'entry[visibility_csv]'}
          value={this.state.hiddenInputValueCSV}
        />
      </div>
    );
  }
  handleChange = (newValue: any, actionMeta: any) => {
    const newInputValue = newValue.map(({ label }) => label).join(',');
    this.setState({ hiddenInputValueCSV: newInputValue });
  };
}

EntryVisibilitySelector.propTypes = {
  allLabels: PropTypes.array.isRequired,
  selectedLabels: PropTypes.array.isRequired,
};

export default EntryVisibilitySelector;
