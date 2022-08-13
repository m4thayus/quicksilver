# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Board Tasks", type: :request, user: :engineer do
  let(:board) { create(:board) }

  xdescribe "GET /boards/:board_id/tasks" do
    it "returns http success" do
      get board_tasks_path
      expect(response).to have_http_status(:success)
    end
  end

  xdescribe "GET /boards/:board_id/tasks/:id" do
    subject { get board_task_path(create(:task)) }

    it "returns http success" do
      subject
      expect(response).to have_http_status(:success)
    end

    context "when task does not exist" do
      subject { get board_task_path(id: :id) }

      it "returns http not found" do
        subject
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  xdescribe "GET /boards/:board_id/tasks/new" do
    it "returns http success" do
      get new_board_task_path
      expect(response).to have_http_status(:success)
    end
  end

  xdescribe "POST /boards/:board_id/tasks" do
    subject { post board_tasks_path, params: params }

    let(:params) { { task: attributes_for(:task) } }

    it "returns http success" do
      subject
      expect(response).to redirect_to board_tasks_path
    end

    it "creates the task" do
      expect { subject }.to change { Task.count }.by(1)
    end

    context "when an owner is set" do
      let(:owner) { create(:user) }

      before do
        params[:task].merge!(owner: { email: owner.email })
      end

      it "returns http success" do
        subject
        expect(response).to redirect_to board_tasks_path
      end

      it "creates the task" do
        expect { subject }.to change { Task.count }.by(1)
      end

      it "has an owner" do
        subject
        expect(Task.last.owner).to eq owner
      end
    end

    context "when bad params present" do
      it "returns http bad request" do
        params[:task].delete(:title)
        subject
        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  xdescribe "GET /boards/:board_id/tasks/edit" do
    it "returns http success" do
      get edit_board_task_path(create(:task))
      expect(response).to have_http_status(:success)
    end
  end

  xdescribe "PUT /boards/:board_id/task/:id" do
    subject { put board_task_path(task), params: params }

    let(:task) { create(:task) }
    let(:params) { { task: { title: "new title" } } }

    it "returns http success" do
      subject
      expect(response).to redirect_to board_task_path(task)
    end

    it "updates the task" do
      expect { subject }.to(change { task.reload.title })
    end

    context "when an owner is set" do
      let(:owner) { create(:user) }
      let(:params) { { task: { owner: { email: owner.email } } } }

      let(:task) { create(:task) }

      it "returns http success" do
        subject
        expect(response).to redirect_to board_task_path(task)
      end

      it "updates the task owner" do
        expect { subject }.to(change { task.reload.owner })
      end
    end

    context "when bad params present" do
      it "returns http bad request" do
        params[:task][:title] = nil
        subject
        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  xdescribe "DELETE /boards/:board_id/tasks/:id" do
    subject { delete board_task_path(task) }

    let!(:task) { create(:task) }

    it "redirects to index" do
      subject
      expect(response).to redirect_to board_tasks_path
    end

    it "destroys the task" do
      expect { subject }.to change { Task.count }.by(-1)
    end

    context "when task does not exist" do
      subject { delete board_task_path(id: :id) }

      it "returns http not found" do
        subject
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
