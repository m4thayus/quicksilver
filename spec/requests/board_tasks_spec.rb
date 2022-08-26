# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Board Tasks", type: :request, user: :engineer do
  let(:board) { create(:board) }

  describe "GET /boards/:board_name/tasks" do
    it "returns http success" do
      get board_tasks_path(board)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /boards/:board_name/tasks/:id" do
    subject { get board_task_path(board, create(:task)) }

    it "returns http success" do
      subject
      expect(response).to have_http_status(:success)
    end

    context "when task does not exist" do
      subject { get board_task_path(board, id: :id) }

      it "returns http not found" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "GET /boards/:board_name/tasks/new" do
    it "returns http success" do
      get new_board_task_path(board)
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /boards/:board_name/tasks" do
    subject { post board_tasks_path(board), params: params }

    let(:params) { { task: attributes_for(:task) } }

    it "returns http success" do
      subject
      expect(response).to redirect_to board_tasks_path(board)
    end

    it "creates the task" do
      expect { subject }.to change { Task.count }.by(1)
    end

    context "when an owner is set" do
      let(:owner) { create(:user) }

      before do
        params[:task].merge!(owner_id: owner.id)
      end

      it "returns http success" do
        subject
        expect(response).to redirect_to board_tasks_path(board)
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

  describe "GET /boards/:board_name/tasks/edit" do
    it "returns http success" do
      get edit_board_task_path(board, create(:task))
      expect(response).to have_http_status(:success)
    end
  end

  describe "PUT /boards/:board_name/task/:id" do
    subject { put board_task_path(board, task), params: params }

    let(:task) { create(:task, board: board) }
    let(:params) { { task: { title: "new title" } } }

    it "returns http success" do
      subject
      expect(response).to redirect_to board_tasks_path(board)
    end

    it "updates the task" do
      expect { subject }.to(change { task.reload.title })
    end

    context "when an owner is set" do
      let(:owner) { create(:user) }
      let(:params) { { task: { owner_id: owner.id } } }

      let(:task) { create(:task, board: board) }

      it "returns http success" do
        subject
        expect(response).to redirect_to board_tasks_path(board)
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

  describe "DELETE /boards/:board_name/tasks/:id" do
    subject { delete board_task_path(board, task) }

    let!(:task) { create(:task, board: board) }

    it "redirects to index" do
      subject
      expect(response).to redirect_to board_tasks_path(board)
    end

    it "destroys the task" do
      expect { subject }.to change { Task.count }.by(-1)
    end

    context "when task does not exist" do
      subject { delete board_task_path(board, id: :id) }

      it "returns http not found" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
