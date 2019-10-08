import React from 'react';
import PropTypes from 'prop-types';

import CreatableSelect from 'react-select/lib/Creatable';

class TagSelector extends React.Component {
  constructor(props) {
    super(props);

    if (props.resourceName != 'leaderbit' && props.resourceName != 'question') {
      throw 'invalid resource name ' + props.resourceName;
    }

    this.state = {
      hiddenInputValueCSV: this.props.selectedLabels.join(','),
    };
  }

  render() {
    const defaultOptions = this.props.allLabels.map(title => ({
      value: title,
      label: title,
    }));

    //TODO in case when there was validation error in previous request - new default value is not present in defaultOptions
    const defaultValue = defaultOptions.filter(option =>
      this.props.selectedLabels.includes(option.label)
    );

    return (
      <div>
        <CreatableSelect
          isMulti
          defaultValue={defaultValue}
          onChange={this.handleChange}
          options={defaultOptions}
        />
        <input
          type="hidden"
          name={this.props.resourceName + '[tags_csv]'}
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

TagSelector.propTypes = {
  resourceName: PropTypes.string.isRequired,
  allLabels: PropTypes.array.isRequired,
  selectedLabels: PropTypes.array.isRequired,
};

export default TagSelector;
