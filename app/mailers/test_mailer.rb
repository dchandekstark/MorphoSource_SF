class TestMailer < ApplicationMailer
  def test_email
    mail(
      from: "simon.choy@duke.edu",
      to: "simon.choy@duke.edu",
      subject: "Test mail",
      body: "Test mail body"
    )
  end
end
