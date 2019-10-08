import React from 'react';
import PropTypes from 'prop-types';
import TagSelector from './TagSelector';

class QuestionInput extends React.Component {
  constructor(props) {
    super(props);

    this.handleSubmit = this.handleSubmit.bind(this);

    this.state = {
      title: this.props.title,
      type: this.props.type,
      mandatory: this.props.mandatory,

      left_side: this.props.left_side,
      right_side: this.props.right_side,
      hint: this.props.hint,
    };
  }

  formIsValid() {
    if (this.state.type == '' || this.state.title == '') {
      return false;
    }

    if (this.isSlider()) {
      if (
        this.state.left_side === '' ||
        this.state.right_side === '' ||
        this.state.right_side <= this.state.left_side
      ) {
        return false;
      }
    }

    return true;
  }

  requestMethod() {
    if (this.props.id) {
      return 'put';
    } else {
      return 'post';
    }
  }

  handleSubmit(event) {
    event.preventDefault();

    if (!this.formIsValid()) {
      return;
    }

    let form = document.querySelector('form');
    let formData = new FormData(form);

    // for (var [key, value] of formData.entries()) {
    //   console.log(key, value);
    // }

    fetch(this.props.url, {
      method: this.requestMethod(),
      credentials: 'include',
      redirect: 'follow',
      body: formData,
    })
      .then(response => {
        return response.json();
      })
      .then(json => {
        window.location.href = json.redirect;
      });
  }

  isSlider() {
    return this.state.type == 'slider';
  }

  render() {
    let submitButtonClassName = this.formIsValid()
      ? 'button'
      : 'button disabled';

    let submitLabel = this.props.id ? 'Update Question' : 'Create Question';

    return (
      <div>
        <form onSubmit={this.handleSubmit} style={{ width: '100%' }}>
          <div className="row">
            <div className="small-6 columns">
              <label className="string required">
                Title<small>required</small>
              </label>
              <input
                value={this.state.title}
                name="title"
                id="question_input"
                className="string"
                type="text"
                onChange={e => this.setState({ title: e.target.value })}
                required={true}
              />
            </div>
          </div>

          <div className="row">
            <div className="small-6 columns">
              <div className="input tags" style={{ marginBottom: '20px' }}>
                <label className="string required">Tags</label>

                <div>
                  <TagSelector
                    resourceName="question"
                    allLabels={this.props.allLabels}
                    selectedLabels={this.props.selectedLabels}
                  />
                </div>
              </div>
            </div>
          </div>

          <div className="row">
            <div className="small-6 columns">
              <label className="string required">
                Type<small>required</small>
              </label>
              <select
                name="type"
                value={this.state.type}
                onChange={e => this.setState({ type: e.target.value })}
                id="type-selector"
                style={{ width: 'auto' }}
              >
                <option key="role-0" />
                <option
                  key="type1"
                  value={gon.global.Question.Types.SINGLE_TEXTBOX}
                >
                  Single Textbox
                </option>
                <option
                  key="type2"
                  value={gon.global.Question.Types.COMMENT_BOX}
                >
                  Comment Box
                </option>
                <option key="type3" value={gon.global.Question.Types.SLIDER}>
                  Slider
                </option>
              </select>
            </div>
          </div>

          {!this.isSlider() && (
            <div className="row">
              <div className="small-6 columns">
                <input
                  type="checkbox"
                  name="mandatory"
                  value={this.state.mandatory}
                />

                <label className="string required">
                  Require an Answer to This Question
                </label>
              </div>
            </div>
          )}
          {this.isSlider() && (
            <div className="row">
              <div className="small-6 columns">
                <fieldset className="fieldset">
                  <h6>Scale Range Labels</h6>
                  <label className="string required">
                    Left Side<small>required</small>
                  </label>

                  <input
                    name="left_side"
                    type="number"
                    required={true}
                    min="0"
                    onChange={e => this.setState({ left_side: e.target.value })}
                    value={this.state.left_side}
                  />

                  <label>
                    Hint<small>optional</small>
                  </label>
                  <input
                    className="string"
                    type="text"
                    name="hint"
                    onChange={e => this.setState({ hint: e.target.value })}
                    value={this.state.hint}
                  />
                  <p className="help-text">For example "0 is not at all"</p>

                  <label className="string required">
                    Rigth Side<small>required</small>
                  </label>
                  <input
                    name="right_side"
                    type="number"
                    required={true}
                    min="0"
                    onChange={e =>
                      this.setState({ right_side: e.target.value })
                    }
                    value={this.state.right_side}
                  />
                </fieldset>
              </div>
            </div>
          )}

          <div className="row">
            <div className="small-12 columns">
              <input
                type="submit"
                name="commit"
                className={submitButtonClassName}
                value={submitLabel}
              />
            </div>
          </div>
        </form>
      </div>
    );
  }
}
QuestionInput.propTypes = {
  url: PropTypes.string.isRequired,
  title: PropTypes.string.isRequired,
  mandatory: PropTypes.bool.isRequired,
  hint: PropTypes.string.isRequired,

  // for passing down to TagSelector
  allLabels: PropTypes.array.isRequired,
  selectedLabels: PropTypes.array.isRequired,
};

export default QuestionInput;
