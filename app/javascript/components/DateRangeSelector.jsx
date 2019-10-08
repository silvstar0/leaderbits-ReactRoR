import React from 'react';
import PropTypes from 'prop-types';

import DateRangePicker from '@wojtekmaj/react-daterange-picker';

class DateRangeSelector extends DateRangePicker {
  onChange = date => this.setState({ date })

  constructor(props) {
    super(props);

    if (props.starts_at && props.ends_at) {
      this.state = {
        date: [props.starts_at, props.ends_at]
      }
    }
  }

  render() {
    return (
      <div style={{ width: '350px', height: '35px', display: 'flex', justifyContent: 'center' }}>
        <DateRangePicker
          onChange={this.onChange}
          required={true}
          value={this.state.date}
        />
      </div>
    );
  }
}

export default DateRangeSelector;
